package com.marivaldojunior.critsense;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.context.properties.ConfigurationPropertiesScan;

@SpringBootApplication
@ConfigurationPropertiesScan
public class CritsenseApiApplication {

    public static void main(String[] args) {
        SpringApplication.run(CritsenseApiApplication.class, args);
    }
}
