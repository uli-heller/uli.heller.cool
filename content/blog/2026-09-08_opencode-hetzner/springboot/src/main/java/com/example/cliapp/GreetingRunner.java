package com.example.cliapp;

import java.time.ZoneId;
import java.time.ZonedDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;

import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.boot.SpringBootVersion;
import org.springframework.stereotype.Component;

@Component
class GreetingRunner implements ApplicationRunner {

	@Override
	public void run(ApplicationArguments args) {
		String name = args.containsOption("name") ? args.getOptionValues("name").get(0) : "World";
		List<String> operands = args.getNonOptionArgs();
		ZonedDateTime now = ZonedDateTime.now(ZoneId.systemDefault()).withNano(0);

		System.out.println();
		System.out.println("Hello, " + name + "!");
		System.out.println("This is a Spring Boot command line application.");
		if (!operands.isEmpty()) {
			System.out.println("Arguments: " + String.join(", ", operands));
		}
		System.out.println("Spring Boot " + SpringBootVersion.getVersion());
		System.out.println("Java " + Runtime.version().feature() + " (" + Runtime.version() + ")");
		System.out.println("Time: " + now.format(DateTimeFormatter.ISO_OFFSET_DATE_TIME));
		System.out.println();
	}

}
