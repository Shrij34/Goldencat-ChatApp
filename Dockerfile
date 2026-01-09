
#----------------Stage 1------------------

# Import docker image with maven installed
FROM maven:3.8.8-eclipse-temurin-17 AS builder

# Add labels to the image to filter out if we have multiple application running
LABEL app=chatapp

# Set working directory
WORKDIR /src

# Copy source code from local to container
COPY . /src

# Build application and skip test cases
RUN mvn clean install -DskipTests=true

#--------------------------------------
# Stage 2
#--------------------------------------

# Import small size java image
FROM eclipse-temurin:17-jre-alpine as deployer

# Install curl
RUN apk add --no-cache curl


# Copy build from stage 1 (builder)
COPY --from=builder /src/target/*.jar /src/target/chatapp.jar

# Expose application port 
EXPOSE 8080

# Start the application

ENTRYPOINT ["java", "-jar", "/src/target/chatapp.jar"]

