K.import("konoha");
K.load("neo4j.k");

void main() {
// create DB
	GraphDatabaseService db = new GraphDatabaseService("http://localhost", 7474);

	String name = "name";
	String nt = "NodeType";
	String ft = "FlowType";
	String fn = "FlowName";
	String tid = "taskid";
	String scr = "script";

	int startIdx;

// create Node1: startEvent
	Node startEvent = db.createNode();
	startEvent.setPropertyString(name, "startEvent");
	startEvent.setPropertyString(nt, "D-flow");
	startEvent.setPropertyString(ft, "startEvent");
	startEvent.setPropertyString(fn, "recoveryA");

// create Node2: dTask1
	Node dTask1 = db.createNode();
	dTask1.setPropertyString(name, "dTask1");
	dTask1.setPropertyString(nt, "D-flow");
	dTask1.setPropertyString(ft, "dTask");
	dTask1.setPropertyString(fn, "recoveryA");
	dTask1.setPropertyString(tid, "30"); // to dTask1.setPropertyInt(tid, 30);
	dTask1.setPropertyString(scr, "p(1);");

// create Node3: dTask2
	Node dTask2 = db.createNode();
	dTask2.setPropertyString(name, "dTask2");
	dTask2.setPropertyString(nt, "D-flow");
	dTask2.setPropertyString(ft, "dTask");
	dTask2.setPropertyString(fn, "recoveryA");
	dTask2.setPropertyString(tid, "31"); // to dTask2.setPropertyInt(tid, 30);
	dTask2.setPropertyString(scr, "p(2);");

// create Node4: endEvent
	Node endEvent = db.createNode();
	endEvent.setPropertyString(name, "endEvent");
	endEvent.setPropertyString(nt, "D-flow");
	endEvent.setPropertyString(ft, "endEvent");
	endEvent.setPropertyString(fn, "recoveryA");

// create Relationships
	startEvent.relationshipTo(dTask1, "startEvent to");
	dTask1.relationshipTo(dTask2, "dTask1 to");
	dTask2.relationshipTo(endEvent, "dTask2 to");

	startIdx = startEvent.idx;
	db.shutdown();

	p(startIdx);
}

main();
