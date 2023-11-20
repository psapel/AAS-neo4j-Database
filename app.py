from flask import Flask, render_template, request, url_for
from dotenv import load_dotenv
from neo4j import GraphDatabase
from py2neo import Graph

app = Flask(__name__)

load_dotenv()

neo4j_uri = "bolt://localhost:7687"
neo4j_username = "neo4j"
neo4j_password = "engx1494"

graph = Graph(neo4j_uri, auth=(neo4j_username, neo4j_password))

def get_handling_device_data(uri, username, password):
    with GraphDatabase.driver(uri, auth=(username, password)) as driver:
        with driver.session() as session:
            query = """
            MATCH (i:Inquiry_1)
            WITH i.HandlingDevice AS InquiryHandlingDevice
            MATCH (tcu)
            WHERE tcu.ManufacturerProductRoot = 'HandlingDevice'
            AND tcu.HandlingDevice = InquiryHandlingDevice
            RETURN InquiryHandlingDevice, COLLECT(tcu) AS MatchingControlUnits
            """
            result = session.run(query)
            return result.data()
        
def run_injection_molding_machine_query(graph):
    cypher_query = """
    MATCH (inquiry:Inquiry_1)
    MATCH (imm)
    WHERE imm.ManufacturerProductRoot = 'InjectionMoldingMachine'
    WITH inquiry, imm,
      (inquiry.MinRequiredClampingForce <= imm.MaxClampingForce) AS OK1,
      (inquiry.ShotVolume <= imm.MaxPlasticizingCapacity) AS OK2,
      (inquiry.GreaterMoldDimension <= imm.GreaterClearDistanceBetweenColumns) AS OK3,
      (inquiry.SmallerMoldDimension <= imm.SmallerClearDistanceBetweenColumns) AS OK4,
      (inquiry.RequiredOpeningStroke <= imm.MaxOpeningStroke) AS OK5
    RETURN imm.idShort AS idShort,
      CASE
        WHEN OK1 AND OK2 AND OK3 AND OK4 AND OK5 THEN 'is technically feasible'
        ELSE 'is not technically feasible'
      END AS feasibility
    """

    result = graph.run(cypher_query).data()
    return result

def get_coolant_data(uri, username, password):
    with GraphDatabase.driver(uri, auth=(username, password)) as driver:
        with driver.session() as session:
            query = """
            MATCH (i:Inquiry_1)
            WITH i.Coolant AS InquiryCoolant
            MATCH (tcu)
            WHERE tcu.ManufacturerProductRoot = 'TemperatureControlUnit'
            AND tcu.Coolant = InquiryCoolant
            RETURN InquiryCoolant, COLLECT(tcu) AS MatchingControlUnits
            """
            result = session.run(query)
            return result.data()

@app.route('/')
def index():
    return render_template('index.html')


@app.route('/query1', methods=['POST'])
def run_query1():
    coolant_data = get_coolant_data(neo4j_uri, neo4j_username, neo4j_password)
    return render_template('result.html', data=coolant_data, query_type='Temperature Control Unit Query')

@app.route('/query2', methods=['POST'])
def run_query2():
    handling_device_data = get_handling_device_data(neo4j_uri, neo4j_username, neo4j_password)
    return render_template('result.html', data=handling_device_data, query_type='Handling Device Query')

@app.route('/query3', methods=['POST'])
def run_query3():
    result = run_injection_molding_machine_query(graph)
    return render_template('result.html', data=result, query_type='Injection Molding Machine Query')

if __name__ == '__main__':
    app.run(debug=True)

