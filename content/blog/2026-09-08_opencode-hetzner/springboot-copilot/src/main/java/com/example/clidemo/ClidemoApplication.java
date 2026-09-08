package com.example.clidemo;

import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;

@SpringBootApplication
public class ClidemoApplication {

	public static void main(String[] args) {
		System.exit(SpringApplication.exit(SpringApplication.run(ClidemoApplication.class, args)));
	}

	@Bean
	CommandLineRunner run() {
		return args -> {
			if (args.length == 0) {
				System.out.println("Hello from your Spring Boot CLI app! Pass a name as an argument to be greeted.");
				return;
			}
			for (String arg : args) {
				System.out.println("Hello, " + arg + "!");
			}
		};
	}

}
