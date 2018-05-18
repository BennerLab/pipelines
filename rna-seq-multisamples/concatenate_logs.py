'''
Simple script for concatenating log files. Append date to log file.
'''
import sys

'''
Function for parsing log files for STAR.
'''
def parse_log_file(log_file):

    out = {}
    f = open(log_file)
    for line in f.readlines():
        line = line.strip()
        if line and line.__contains__("|"):
            line = line.split("|")
            line[1] = line[1].strip()
            if line[0] in ["Number of input reads ","Uniquely mapped reads number ","Uniquely mapped reads % ",
                           "Number of reads mapped to multiple loci ","% of reads mapped to multiple loci ",
                           "Number of reads mapped to too many loci ","% of reads mapped to too many loci "]:
                out[line[0][:-1]] = line[1]

    return out

def main():

    #Grab log folder and log files.
    log_destination = sys.argv[1]
    log_files = sys.argv[2:]

    #Write to a new log file.
    out = open(log_destination, "w")
    out.write("Experiment\tTotal Reads\tTotal Uniquely Mapped Reads\t% Uniquely Mapped Reads\tTotal Multimapped Reads\t% Multimapped Reads\tTotal Unmapped Reads\t% Unmapped Reads")
    for log_file in log_files:
        log_dict = parse_log_file(log_file)
        unmapped_reads = int(log_dict["Number of input reads"]) - int(log_dict["Uniquely mapped reads number"]) - \
                         int(log_dict["Number of reads mapped to multiple loci"]) - \
                         int(log_dict["Number of reads mapped to too many loci"])
        percent_unmapped = round(unmapped_reads / float(log_dict["Number of input reads"]) * 100, 2)
        log_file_name = log_file[19:-14]
        out.write(f"\n{log_file_name}\t{log_dict['Number of input reads']}\t{log_dict['Uniquely mapped reads number']}\t{log_dict['Uniquely mapped reads %']}\t{log_dict['Number of reads mapped to multiple loci']}\t{log_dict['% of reads mapped to multiple loci']}\t{unmapped_reads}%\t{percent_unmapped}%")
    out.close()

if __name__ == '__main__':
    main()