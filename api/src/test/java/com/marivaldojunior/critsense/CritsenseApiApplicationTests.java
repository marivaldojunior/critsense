package com.marivaldojunior.critsense;

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.context.annotation.Import;
import org.testcontainers.junit.jupiter.Testcontainers;

/**
 * Sobe o contexto completo contra um PostgreSQL real (Testcontainers), incluindo as migrações do
 * Flyway e a validação do schema pelo Hibernate. Sem Docker na máquina, o teste é pulado; no CI ele
 * sempre roda.
 */
@Testcontainers(disabledWithoutDocker = true)
@Import(TestcontainersConfiguration.class)
@SpringBootTest
class CritsenseApiApplicationTests {

    @Test
    void contextLoads() {}
}
