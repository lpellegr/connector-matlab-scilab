importPackage(java.lang);
importPackage(java.io);
importClass(org.ow2.proactive.scheduler.ext.matlab.worker.util.MatlabEngineConfig);
importClass(org.ow2.proactive.scheduler.ext.matlab.worker.util.MatlabFinder);
try {
    try {
        nodeName = MatlabEngineConfig.getNodeName();
    }
    catch (e) {
        nodeName = "DummyNode";
    }

    tmpPath = System.getProperty("java.io.tmpdir");

    logFileJava = new File(tmpPath, "CheckMatlab" + nodeName + ".log");

    fos = new FileOutputStream(logFileJava);
    logout = new PrintStream(fos);

    orig_jstdout = System.out;
    orig_jstderr = System.err;

    System.setOut(logout);
    System.setErr(logout);

    debug = (args[0] == "true");
    cpt = 1;
    versionPref = null;
    versionMin = null;
    versionMax = null;
    versionRej = null;
    while (cpt < args.length)
        switch (args[cpt]) {
            case "versionPref":
                versionPref = args[cpt + 1];
                break;
            case "versionMin":
                versionMin = args[cpt + 1];
                break;
            case "versionMax":
                versionMax = args[cpt + 1];
                break;
            case "versionRej":
                versionRej = args[cpt + 1];
                break;
        }
    end
    cpt += 2
    end
    try {
        cf = MatlabFinder.getInstance().findMatSci(versionPref, versionRej, versionMin, versionMax, debug);
    }
    catch (e) {
        e.printStackTrace();
    }
    if (cf == nil) {
        System.out.println("KO");
        selected = false;
    }
    else {
        System.out.println(cf);
        MatlabEngineConfig.setCurrentConfiguration(cf);
        selected = true;
    }
} finally {
    System.setOut(orig_jstdout);
    System.setErr(orig_jstderr);
    try {
        logout.close();
        fos.close();
    } catch (e) {
    }
}	
