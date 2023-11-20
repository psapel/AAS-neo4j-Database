from flask import Flask, render_template, request, url_for
from dotenv import load_dotenv
from neo4j import GraphDatabase
from py2neo import Graph

from queries.coolant_query import get_coolant_data
from queries.handling_device_query import get_handling_device_data
from queries.injection_molding_machine_query import run_injection_molding_machine_query

app = Flask(__name__)

load_dotenv()

neo4j_uri = "bolt://localhost:7687"
neo4j_username = "neo4j"
neo4j_password = "engx1494"

graph = Graph(neo4j_uri, auth=(neo4j_username, neo4j_password))


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

