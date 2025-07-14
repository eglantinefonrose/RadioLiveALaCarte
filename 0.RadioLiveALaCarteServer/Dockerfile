FROM gradle:8.4-jdk21 AS build
WORKDIR /groovymorningfm

# Copy Gradle build scripts first to leverage caching
COPY settings.gradle ./
COPY app/build.gradle app/

# Download dependencies only (this caches the dependencies layer)
RUN gradle app:dependencies --no-daemon || true
RUN gradle app:copyRuntimeDeps --no-daemon

# Copy the full source code
COPY . .

# Build the application
RUN gradle build --no-daemon

FROM eclipse-temurin:21-jre
WORKDIR /groovymorningfm

# Copy the app jar
COPY --from=build /groovymorningfm/app/build/libs/*.jar app.jar

# Copy dependencies
COPY --from=build /groovymorningfm/app/build/dependencies ./dependencies

# Run the app with classpath including all dependencies
ENTRYPOINT ["java", "-cp", "app.jar:dependencies/*", "com.proutechos.sandbox.radiolivealacarte.server.EntryPoint"]

EXPOSE 8287
