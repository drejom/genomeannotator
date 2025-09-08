process REPEATMASKER_STAGELIB {

    tag "$fasta"
    label 'process_low'
    
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/repeatmasker:4.1.2.p1--pl5321hdfd78af_1':
        'quay.io/biocontainers/repeatmasker:4.1.2.p1--pl5321hdfd78af_1' }"

    input:
    path fasta
    val species
    path db
    path my_genome_fa
    path repeats_fa

    output:
    path "Libraries", emit: library
    path "versions.yml", emit: versions

    script:
    def options = ""
    if (species) {
       options = "-species $species"
    } else {
       options = "-lib $fasta"
    }
    """
       cp $my_genome_fa my_genome.fa
       cp $repeats_fa repeats.fa
       cp -R /usr/local/share/RepeatMasker/Libraries .
       cp $db Libraries/Dfam.h5
       export LIBDIR=\$PWD/Libraries
       RepeatMasker $options my_genome.fa > out

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        repeatmasker: \$(echo \$(RepeatMasker -v 2> /dev/null) | cut -f3 -d " "| sed "s/[)]//") )
    END_VERSIONS
    """
}
