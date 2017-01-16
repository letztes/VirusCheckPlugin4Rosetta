#!/bin/bash
# Andreas Romeyke, SLUB Dresden
# Artur Spengler,  TIB Hannover

# Pfad zu Java 8
JAVAPATH=$(wildcard /exlibris/dps/d4_1/product/local/java/bin/)

# Verwendete Rosetta-Version
ROSETTAVERSION=5.0.1

# Pfad zum Rosetta-SDK
ROSETTASDK=/exlibris/dps/d4_1/system.dir/dps-sdk-${ROSETTAVERSION}/lib/
# Pfad zum Rosetta-SDK, Deposit-Module
ROSETTASDKDEPOSIT=${ROSETTASDK}/../dps-sdk-projects/dps-sdk-deposit/lib
ROSETTASDKPLUGINS=${ROSETTASDK}/../../bundled_plugins/


# classpath
#~ JUNITCLASSPATH=/usr/share/java/junit4.jar
CLASSPATH=./java:${ROSETTASDKDEPOSIT}/../src/:${ROSETTASDKDEPOSIT}/xmlbeans-2.3.0.jar:${ROSETTASDKDEPOSIT}/dps-sdk-${ROSETTAVERSION}.jar:${ROSETTASDKDEPOSIT}/log4j-1.2.14.jar:${ROSETTASDKPLUGINS}/NFSStoragePlugin.jar

# sources
SOURCES=java/org/slub/rosetta/dps/repository/plugin/SLUBVirusCheckClamAVPlugin.java
OBJS=$(SOURCES:.java=.class)
JAR=SLUBVirusCheckPlugin.jar

all: $(JAR)

help:
        @echo "erzeugt Storage-Plugin für Rosetta von Exlibris"
        @echo ""
        @echo "Das Argument 'clean' löscht temporäre Dateien, 'help' gibt diese Hilfe aus und"
        @echo "'compile' erzeugt ein JAR-File und ein Bash-Script welches das Java-Programm"
        @echo "aufruft."

jarclean:
        @rm -Rf build

#~ test:   $(OBJS)
        #~ java -cp ${CLASSPATH}:$(JUNITCLASSPATH) org.junit.runner.JUnitCore

clean: jarclean
        @rm -Rf doc/
        find ./java/org/ -name "*.class" -exec rm -f \{\} \;
        @rm -Rf $(JAR)

distclean: clean
        find ./ -name "*~" -exec rm -f \{\} \;
        @rm -Rf null

$(JAR): $(OBJS)
        @mkdir build;
        @cp -r PLUGIN-INF/ build/
        @cp -r META-INF/ build/
#       @cd java; find ./ -name "*.class" -print -exec cp --parents -r \{\} $(PWD)/build \; ; cd .. # no --parents for cp on sunos
        @cd java; find ./ -name "*.class" -print | cpio -pdm $(PWD)/build ; cd ..
        @cd build; ${JAVAPATH}/jar cfvM ../$@ ./* ; cd ..
    
%.class: %.java
        #~ ${JAVAPATH}/javac -classpath ${CLASSPATH}:${JUNITCLASSPATH} -Xlint:all $< # no junit so far
        ${JAVAPATH}/javac -classpath ${CLASSPATH} -Xlint:all $<

doc: $(SOURCES)
        javadoc -d doc/ $^

check_prerequisites:
        @echo -n "### Checking java path: $(JAVAPATH) ...."
        @if [ -e $(JAVAPATH) ]; then echo "fine :)"; else echo " not found! :("; fi
        @echo -n "### Checking Exlibris Rosetta SDK path: $(ROSETTASDK) ...."
        @if [ -e $(ROSETTASDK) ]; then echo "fine :)"; else echo " not found! :("; fi

.PHONY: help clean distclean jarclean test
