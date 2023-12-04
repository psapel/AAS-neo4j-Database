from neo4j import GraphDatabase

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