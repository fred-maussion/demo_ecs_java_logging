# ────────────────────────────────────────────
# BUILD STAGE: Build the application using Maven
# ────────────────────────────────────────────
FROM maven:3.9.6-eclipse-temurin-17 AS build

# Set working directory
WORKDIR /app

# Copy Maven project files
COPY pom.xml .
COPY src ./src

# Build the project (Skipping tests if needed)
RUN mvn clean package -DskipTests

# ────────────────────────────────────────────
# RUNTIME STAGE: Run the application with Java 17
# ────────────────────────────────────────────
FROM eclipse-temurin:17-jre

# Set working directory
WORKDIR /app

# Expose application port
EXPOSE 8080

# Copy the built JAR from the build stage
COPY --from=build /app/target/*.jar app.jar

# Set entrypoint to run the application
CMD ["java", "-jar", "app.jar"]
