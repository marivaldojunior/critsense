# Build em duas etapas: o JDK só existe na etapa de build; a imagem final
# tem só o JRE e o JAR da API.
FROM eclipse-temurin:21-jdk AS build
WORKDIR /workspace

# Baixa as dependências antes de copiar o código, para o Docker reaproveitar
# esta camada quando só o código mudar.
COPY mvnw pom.xml ./
COPY .mvn .mvn
RUN chmod +x mvnw && ./mvnw -q -B dependency:go-offline

COPY src src
RUN ./mvnw -q -B -DskipTests package

FROM eclipse-temurin:21-jre
WORKDIR /app

RUN groupadd --system critsense && useradd --system --gid critsense critsense
USER critsense

COPY --from=build /workspace/target/critsense-api-*.jar app.jar

EXPOSE 8080
ENTRYPOINT ["java", "-jar", "/app/app.jar"]
