# AAS-neo4j-Database
Graphical DB for enabling active AAS communication
First, it creates a node labeled 'IMM' with a property asset set to 'IMM' and a relationship of type 'Equipped_with' to a node labeled 'Mold' with a property asset set to 'Mold'.
The 'WITH *' statement passes all the results from the previous clause to the next clause.
The next clasue is the 'WITH *' statement passes all the results from the previous clause to the next clause, which is a 'MATCH' statement. This statement retrieves the IMM node and the Mold node that are connected by the Equipped_with relationship, and assigns them to the variables imm and mold, respectively.
The 'RETURN' statement returns the imm and mold nodes along with their labels, which should be ['IMM'] and ['Mold'], respectively.
The next part of the script loads a JSON file for an 'Arburg_XXX' instance and creates a node labeled 'Arburg_XXX' with properties for 'asset' and 'manufacturer'. Then it connects the existing 'IMM' node to the new 'Arburg_XXX' node with a relationship labeled 'is_a'.
Similarly, it loads a JSON file for a 'SGO24' instance and creates a node labeled 'SGO24' with properties for 'asset' and 'name'. Then it connects the existing Mold node to the new 'SGO24' node with a relationship labeled 'is_a'.
The 'WITH *' clauses pass all the results from the previous clause to the next clause.
The 'MATCH' clauses retrieve the existing 'IMM' and 'Mold' nodes that are needed to create the relationships with the new nodes. 
The 'MERGE' clauses create the new nodes if they don't already exist or merge with existing nodes if they do. 
Finally, the 'CALL' statement loads the JSON files and the 'YIELD' statement assigns the JSON data to variables for later use in the script.
