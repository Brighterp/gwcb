cls
Echo compiling Report .....
for %%f IN (*.RDF) do C:\orant6i\BIN\RWCON60 userid=web4/web4@orcl10ga batch=yes source=%%f stype=rdffile DTYPE=REPFILE OVERWRITE=yes logfile=log.txt 
ECHO FINISHED COMPILING