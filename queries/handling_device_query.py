from neo4j import GraphDatabase

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