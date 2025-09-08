process AUGUSTUS_STAGECONFIG {
    tag "${augustus_config_dir}"
    label 'process_low'
    
    conda (params.enable_conda ? "bioconda::augustus=3.4.0" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/augustus:3.4.0--pl5262h5a9fe7b_2':
        'quay.io/biocontainers/augustus:3.4.0--pl5262h5a9fe7b_2' }"

    input:
    path augustus_config_dir

    output:
    path "augustus_config", emit: config_dir
    path "versions.yml"           , emit: versions

    script:
    """
    mkdir -p augustus_config
    
    # If augustus_config_dir is just "config", copy from the container's default location
    if [[ "$augustus_config_dir" == "config" ]]; then
        # Copy Augustus config from container's default location
        cp -R /usr/local/config/* augustus_config/
    else
        # Use the provided path (either absolute container path or staged directory)
        cp -R $augustus_config_dir/* augustus_config/
    fi

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        augustus: \$(echo \$(augustus  | head -n1 | cut -f2 -d " " | sed "s/[)]//" | sed "s/[(]//" ))
    END_VERSIONS
    """
}
