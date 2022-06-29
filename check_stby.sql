select rec.thread#, rec.last_rec "Last Sequence Received", app.last_app "Last Sequence Applied"
from
(select thread#, max(sequence#) last_rec
from v$archived_log
where resetlogs_id = (select max(resetlogs_id) from v$archived_log)
group by thread#) rec,
(select thread#, max(sequence#) last_app
from v$archived_log
where resetlogs_id = (select max(resetlogs_id) from v$archived_log)
and applied='YES' and registrar='RFS'
group by thread#) app
where rec.thread#=app.thread#
and rec.thread# != 0
order by rec.thread#
/