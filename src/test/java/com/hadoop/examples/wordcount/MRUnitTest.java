package com.hadoop.examples.wordcount;

import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.LongWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mrunit.mapreduce.MapDriver;
import org.apache.hadoop.mrunit.mapreduce.MapReduceDriver;
import org.apache.hadoop.mrunit.mapreduce.ReduceDriver;
import org.junit.Before;
import org.junit.Test;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

public class MRUnitTest {

    MapDriver<LongWritable, Text, Text, IntWritable> mapDriver;
    ReduceDriver<Text, IntWritable, Text, IntWritable> reduceDriver;
    MapReduceDriver<LongWritable, Text, Text, IntWritable, Text, IntWritable> mapReduceDriver;

    @Before
    public void setUp() {

        TokenizingMapper mapper = new TokenizingMapper();
        mapDriver = new MapDriver<>();
        mapDriver.setMapper(mapper);

        SumReducer reducer = new SumReducer();
        reduceDriver = new ReduceDriver<>();
        reduceDriver.setReducer(reducer);

        mapReduceDriver = new MapReduceDriver<>();
        mapReduceDriver.setMapper(mapper);
        mapReduceDriver.setReducer(reducer);
    }

    @Test
    public void testMapper() throws IOException {

        mapDriver.withInput(new LongWritable(1),
                new Text("1 cat cat dog"));
        mapDriver.withOutput(new Text("1"), new IntWritable(1));
        mapDriver.withOutput(new Text("cat"), new IntWritable(1));
        mapDriver.withOutput(new Text("cat"), new IntWritable(1));
        mapDriver.withOutput(new Text("dog"), new IntWritable(1));

        mapDriver.runTest();
    }

    @Test
    public void testReducer() throws IOException {

        List<IntWritable> list = new ArrayList<>();
        list.add(new IntWritable(1));
        list.add(new IntWritable(1));

        reduceDriver.withInput(new Text("cat"), list);
        reduceDriver.withOutput(new Text("cat"), new IntWritable(2));

        reduceDriver.runTest();
    }

    @Test
    public void testMapReduce() throws IOException {

        List<IntWritable> list = new ArrayList<>();
        list.add(new IntWritable(1));
        list.add(new IntWritable(1));

        mapReduceDriver.withInput(new LongWritable(1), new Text("cat cat dog"));
        mapReduceDriver.withOutput(new Text("cat"), new IntWritable(2));
        mapReduceDriver.withOutput(new Text("dog"), new IntWritable(1));

        mapReduceDriver.runTest();
    }
}
