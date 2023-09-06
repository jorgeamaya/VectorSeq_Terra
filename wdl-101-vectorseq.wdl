version 1.0

workflow insecticide_resistance_detect {
	input {
		File ASVBimeras
		File seqtab_mixed
	}
	call asv_resistance_process {
		input:
			ASVBimeras = ASVBimeras,
			seqtab_mixed = seqtab_mixed
	}

	output {
		File ASV_ID_and_Sequences_f = asv_resistance_process.ASV_ID_and_Sequences
		File Top2ASV_sequences2_f = asv_resistance_process.Top2ASV_sequences2
		File vgsc_out_f = asv_resistance_process.vgsc_out
		File Filtered_seqtab_132bp_nonred_f = asv_resistance_process.Filtered_seqtab_132bp_nonred
		File Top2ASVs_perSample_f = asv_resistance_process.Top2ASVs_perSample
		File Number_of_sampled_reads_f = asv_resistance_process.Number_of_sampled_reads
	}
}

task asv_resistance_process {
	input {
		File ASVBimeras
		File seqtab_mixed
	}

	Map[String, String] in_map = {
		"ASVBimeras": sub(ASVBimeras, "gs://", "/cromwell_root/"),
		"seqtab_mixed": sub(seqtab_mixed, "gs://", "/cromwell_root/"),
	}
	File config_json = write_json(in_map)
	command <<<
	set -euxo pipefail
	#set -x

	mkdir Results

	Rscript script1_vgsc.R
	Rscript script2_vgsc.R

	perl FindKmersASVs.pl -k vgsc_kmers.txt -f Results/Top2ASV_sequences2.fasta -o Results/vgsc_out.txt

	find . -type f
	>>>

	output {
		File ASV_ID_and_Sequences = "Results/ASV_ID_and_Sequences.csv"
		File Top2ASV_sequences2 = "Results/Top2ASV_sequences2.fasta"
		File vgsc_out = "Results/vgsc_out.txt"
		File Filtered_seqtab_132bp_nonred = "Results/Filtered_seqtab_132bp_nonred.csv"	
		File Top2ASVs_perSample = "Results/Top2ASVs_perSample.csv"
		File Number_of_sampled_reads = "Results/Number_of_sampled_reads.png"
	}

	runtime {
		cpu: 1
		memory: "10 GiB"
		disks: "local-disk 10 HDD"
		bootDiskSizeGb: 10
		preemptible: 3
		maxRetries: 1
		docker: 'jorgeamaya/vector_seq:v1'
	}
}