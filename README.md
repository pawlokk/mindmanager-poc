# mindmanager-poc
public disclosure:

Affected application: MindManager23_setup.exe
Platform: Windows
Issue: Local Privilege Escalation via MSI installer Repair Mode (EXE hijacking race condition) 
Discovered and reported by: Pawel Karwowski and Julian Horoszkiewicz (Eviden Red Team)

Proposed mitigation:
https://learn.microsoft.com/en-us/windows/win32/msi/disablemsi

Reasoning for public disclosure: 
Sitting on this indefinitely in the long run benefits threat actors (the issue is trivial to find), while keeping users and administrators in the dark, unaware of the risk.

What is the vendor's position? 
According to the vendor it is not their responsibility, as the vulnerability lies in a 3rd party component (CVE-2021-41526). This doesn't mean that their software isn't vulnerable, though.
We originally reported this issue to vendor on 22.08.2023. Since then, we could not convince them to release a fix, even despite involving US CERT into coordination efforts. After prolonged period of exchanging messages back and forth, we agreed with CERT that in this situation public disclosure is the proper course of action.

What's the vulnerability?
On systems with MindManager23 installed, it is possible for regular users to trigger the installer in "repair" mode, by issuing the following command:
msiexec.exe /fa PATH_TO_INSTALLER_FILE.msi

This triggers the msiexec service, which carries the repair process, running multiple actions and, among others, creates files inside of the C:\Users\pk\AppData\Local\Temp directory, which have their filenames dynamically generated, in the following pattern: "wac<four random letters or numbers>.tmp", for example, wac98DF.tmp.
The process then uses the generated wac****.tmp file (executable) running as NT AUTHORITY/SYSTEM to write to, and load an image of itself.

Since the C:\Users\pk\AppData\Local\ directory is owned by the regular user, the C:\Users\pk\AppData\Local\Temp\ directory inherits the permissions, making it possible for the regular user to interfere with the contents of the directory, for example by overwriting the dynamically generated DLL\EXE files.

The privilege escalation in Mind Manager installer is caused by its use of a known vulnerable component - Flexera Installshield, affected by CVE-2021-41526. Mind Manager should use an up-to-date version of the Flexera Installshield - or repacakge the MSI so it does not support "repair mode", or requires administrative privileges to run it.

What is the exploitation process?
Exploitation is done with the use of a powershell script that runs the .MSI file, checks for the presence and creation of our legit DLL\EXE of interest, and repeatedly copies the Proof of Concept DLL\EXE into the Appdata\Local\Temp directory, effectively overwriting the legit DLL\EXE file. After being ran, the PoC DLL\EXE file creates a poc.txt file in C:\Users\Public, together with the command line that called it, and whoami output.

