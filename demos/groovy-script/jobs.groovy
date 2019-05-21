import groovy.json.JsonSlurper

def json = new JsonSlurper().parse("https://jobs.github.com/positions.json?description=groovy".toURL()) as List<Map>

json.each {
    println ("\n" + "=" * 42)
    println it.title
    println it.location
    println "@ ${it.company}"
    println it.created_at
    println it.url
    println ("=" * 42)
}