from neo4j import GraphDatabase

def get_HandlingDevice_data(uri, username, password):
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

neo4j_uri = "bolt://localhost:7687"
neo4j_username = "neo4j"
neo4j_password = "engx1494"

HandlingDevice_data = get_HandlingDevice_data(neo4j_uri, neo4j_username, neo4j_password)

for record in HandlingDevice_data:
    print("InquiryHandlingDevice:", record["InquiryHandlingDevice"])
    print("HandlingDevice Comparison:")
    matching_control_units = record["MatchingControlUnits"]
    if matching_control_units:
        for unit in matching_control_units:
            print("Matched with:", unit["idShort"])  
    print()
