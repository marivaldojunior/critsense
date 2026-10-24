package com.marivaldojunior.critsense;

import org.springframework.boot.SpringApplication;

public class TestCritsenseApiApplication {

    public static void main(String[] args) {
        SpringApplication.from(CritsenseApiApplication::main)
                .with(TestcontainersConfiguration.class)
                .run(args);
    }
}
