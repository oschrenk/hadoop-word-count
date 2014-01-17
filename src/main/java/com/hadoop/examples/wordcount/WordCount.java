package com.hadoop.examples.wordcount;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.conf.Configured;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.input.TextInputFormat;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;
import org.apache.hadoop.mapreduce.lib.output.TextOutputFormat;
import org.apache.hadoop.util.Tool;
import org.apache.hadoop.util.ToolRunner;

/**
 * The famous MapReduce word count examples for Hadoop.
 */
public class WordCount extends Configured implements Tool {

	public static void main(String[] args) throws Exception {
		int res = ToolRunner.run(new Configuration(), new WordCount(), args);
		System.exit(res);
	}

	@Override
	public int run(String[] args) throws Exception {

		if (args.length != 2) {
			System.err
					.println("Usage: hadoop jar target/*-job.jar <in> <out>");
			System.err.println();
			ToolRunner.printGenericCommandUsage(System.err);
			return 1;
		}

        // specify configuration and name
		Job job = new Job(getConf(), "WordCount");
        // set jar as the jar that contains myself
		job.setJarByClass(getClass());

        // specify mapper and reducer
		job.setMapperClass(TokenizingMapper.class);
        job.setReducerClass(SumReducer.class);

        // we could also use the provided IntSumReducer
		//job.setReducerClass(IntSumReducer.class);

        // set input format and practically the input key/value)
        job.setInputFormatClass(TextInputFormat.class);
        // set output format
        job.setOutputFormatClass(TextOutputFormat.class);

        // needs to be configured because of Java's type erasure
        job.setMapOutputKeyClass(Text.class);
        job.setMapOutputValueClass(IntWritable.class);

        // needs to be configured because of Java's type erasure
		job.setOutputKeyClass(Text.class);
		job.setOutputValueClass(IntWritable.class);

        // set combiner
        job.setCombinerClass(SumReducer.class);

        // specify what to load
		FileInputFormat.addInputPath(job, new Path(args[0]));
		FileOutputFormat.setOutputPath(job, new Path(args[1]));

		boolean success = job.waitForCompletion(true);
		return success ? 0 : 1;
	}
}
