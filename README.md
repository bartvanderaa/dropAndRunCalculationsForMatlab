dropAndRunCalculationsForMatlab
===============================

Algorithm details:
- Drag-and-drop .m-file calculation scripts into a serial server session, e.g. on a remote Linux server with a local SSH (screen) session.
- The overhead script continuously looks for new excecutable scripts, and runs them if new files are found.
- The oldest files in the folder are computed first.
- A three-stage folder structure (toBeProcessed, processing, processed) is used to avoid infinite excecution.
- Excecutable m-files are written as usual, but storage of the .mat-file is done according to, e.g. savePath = fileparts(pwd); save([savePath '/mat/solutions.mat']);
- Avoid using clear-statements in the excecutable scripts, otherwise the folder-structure is deleted too.

Update log:<br>
2014-07-28: initial version created<br>
2014-08-20: rewritten as a function<br>

Bart van der Aa<br>
Division of Applied Acoustics<br>
Chalmers University of Technology<br>
www.ta.chalmers.se<br>
info@bartvanderaa.com<br>
===============================
