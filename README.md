# AAS-neo4j-Database

Graphical DB for enabling active AAS communication

The DB consists of 2 nodes, labeled repsectivaly 'IMM' and 'Mold' amd a relationship between them of type 'Equipped with'. The 'IMM' node contains the property 'asset' that is set to 'IMM'  and the 'Mold' node containsthe property 'asset' that is set to 'Mold'.

The 'WITH *' clause passes all the results from the previous clause to the next clause.

Next one is the 'MATCH' clause that retrieves the IMM node and the Mold node that are connected by the Equipped_with relationship, and assigns them to the variables imm and mold, respectively.

The 'RETURN' clause returns the imm and mold nodes along with their labels, which should be ['IMM'] and ['Mold'], respectively.

The next part of the script loads a JSON file for an 'Arburg_XXX' instance and creates a node labeled 'Arburg_XXX' with properties for 'asset' and 'manufacturer'. Then it connects the existing 'IMM' node to the new 'Arburg_XXX' node with a relationship labeled 'is_a'.

Similarly, it loads a JSON file for a 'SGO24' instance and creates a node labeled 'SGO24' with properties for 'asset' and 'name'. Then it connects the existing Mold node to the new 'SGO24' node with a relationship labeled 'is_a'.

The 'WITH *' clauses pass all the results from the previous clause to the next clause.

The 'MATCH' clauses retrieve the existing 'IMM' and 'Mold' nodes that are needed to create the relationships with the new nodes. 

The 'MERGE' clauses either create new nodes, given they don't pre-exist or merge with already exisitng nodes. 

Finally, the 'CALL' clause loads the JSON files and the 'YIELD' clause assigns the JSON data to the desired variables.
