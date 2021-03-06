% PAjobResult returns or prints the textual representation of the result of the given
% Scheduler job 
%
% Syntax
%
%       >> PAjobResult(jobid);
%       >> out = PAjobResult(jobid)
%
% Inputs
%       
%       jobid - the id of the job (string or numeric)
%
% Outputs
%
%       out - a string containing the result
%
% Description
%
%       PAjobResult returns or prints the textual representation of the result of the given
%       Scheduler job. This function is for convenient-use only, it is mainly 
%       used to look at results of jobs handled by the scheduler which are not 
%       Matlab jobs as PAjobResult won't return the actual Matlab object
%       result. To get the actual Matlab object result, use PAgetResults.
%       To get the output log of the given job, use PAjobOutput.
%
% See also
%       PAgetResults, PAjobOutput, PAtaskResult, PAtaskOutput

%
% /*
%   * ################################################################
%   *
%   * ProActive Parallel Suite(TM): The Java(TM) library for
%   *    Parallel, Distributed, Multi-Core Computing for
%   *    Enterprise Grids & Clouds
%   *
%   * Copyright (C) 1997-2011 INRIA/University of
%   *                 Nice-Sophia Antipolis/ActiveEon
%   * Contact: proactive@ow2.org or contact@activeeon.com
%   *
%   * This library is free software; you can redistribute it and/or
%   * modify it under the terms of the GNU Affero General Public License
%   * as published by the Free Software Foundation; version 3 of
%   * the License.
%   *
%   * This library is distributed in the hope that it will be useful,
%   * but WITHOUT ANY WARRANTY; without even the implied warranty of
%   * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   * Affero General Public License for more details.
%   *
%   * You should have received a copy of the GNU Affero General Public License
%   * along with this library; if not, write to the Free Software
%   * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307
%   * USA
%   *
%   * If needed, contact us to obtain a release under GPL Version 2 or 3
%   * or a different license than the AGPL.
%   *
%   *  Initial developer(s):               The ProActive Team
%   *                        http://proactive.inria.fr/team_members.htm
%   *  Contributor(s):
%   *
%   * ################################################################
%   * $$PROACTIVE_INITIAL_DEV$$
%   */
function varargout = PAjobResult(jobid)
    if isnumeric(jobid)
        jobid = num2str(jobid);
    end
    PAensureConnected();

    sched = PAScheduler;
    solver = sched.PAgetsolver();
    try
        output = solver.jobResult(jobid);
    catch
        PAensureConnected();
        output = solver.jobResult(jobid);
    end
    disp(output);
    if nargout == 1        
        varargout{1} = output;                        
    end
end