function PAtaskResult(jobid,taskname)
    global ('PA_connected','PA_solver');
    if ~PAisConnected()
        error('A connection to the ProActive scheduler is not established, see PAconnect');
    end
    if or(type(jobid)==[1 5 8]) then
        jobid = string(jobid);
    end
    
    txt = jinvoke(PA_solver,'taskResult',jobid,taskname);
    printf('%s\n',txt);   
endfunction