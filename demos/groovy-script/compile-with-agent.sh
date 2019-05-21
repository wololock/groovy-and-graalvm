#!/usr/bin/env bash

if [[ -z ${GROOVY_HOME+x} ]]; then
    echo "ERROR: environment variable GROOVY_HOME is not set..."
    exit 1
fi

mkdir -p out/

GROOVY_VERSION=`groovy -version | awk '{print $3}'`

CLASSPATH="./out/:$GROOVY_HOME/lib/groovy-$GROOVY_VERSION.jar:$GROOVY_HOME/lib/groovy-json-$GROOVY_VERSION.jar"


if [[ ! -f ./out/jobs.class ]]; then
    echo "Compiling the script..."
    groovyc -d=out/ --configscript=compiler.groovy jobs.groovy
fi

#
# ATTENTION: GraalVM 19.0.0 requires removing java.lang.reflect.Executable from generated reflect-config.json file!!!
#
if [[ ! -f ./out/conf/reflect-config.json ]]; then
    echo "Prepring native-image configuration files..."
    java -agentlib:native-image-agent=config-output-dir=out/conf/ \
        -cp ${CLASSPATH} \
        jobs >/dev/null
fi

echo "Compiling GraalVM native image..."

native-image --no-server \
    -cp "${CLASSPATH}" \
    --allow-incomplete-classpath \
    --no-fallback \
    --report-unsupported-elements-at-runtime \
    --initialize-at-build-time \
    --initialize-at-run-time=org.codehaus.groovy.control.XStreamUtils,groovy.grape.GrapeIvy \
    -H:ConfigurationFileDirectories=out/conf/ \
    --enable-url-protocols=http,https \
    jobs
