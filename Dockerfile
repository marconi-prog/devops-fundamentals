FROM eclipse-temurin:25-jdk AS build

WORKDIR /app

COPY . .

RUN ./mvnw clean package -DskipTests


FROM eclipse-temurin:25-jre

WORKDIR /app

COPY --from=build /app/target/devops-fundamentals-0.0.1-SNAPSHOT.jar app.jar

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]