CLS
@ECHO OFF
ECHO ............................... COMPILING REPORTS ........................
ECHO ..........................................................................
ECHO ..........................................................................
ECHO ..........................................................................
ECHO ..........................................................................
ECHO ...... ......................Running Batch Compile .......................
ECHO ..........................................................................
ECHO ..........................................................................
ECHO ..........................................................................
ECHO ..........................................................................
FOR %%f IN (*.RDF) DO RWCON60 USERID=BRIGHT/BRIGHT@10GA BATCH=YES SOURCE=%%f STYPE=RDFFILE DTYPE=REPFILE OVERWRITE=YES LOGFILE=LOG.TXT
ECHO ............................... COMPILING FINISHED........................
ECHO ..........................................................................
ECHO ..........................................................................
ECHO ..........................................................................
ECHO ..........................................................................
ECHO            YOU CAN REVIEW THE LOG FILE FOR COMPILING DETAILS
ECHO ..........................................................................

