workflow hello_wf {
    String message
    Int ncpus_greeting
    Int ramGB_greeting
    String disks_greeting

    call greeting { input:
        message = message,
        ncpu = ncpus_greeting,
        ramGB = ramGB_greeting,
        disks = disks_greeting,
    }
}

task greeting {
    String message
    Int ncpu
    Int ramGB
    String disks

    command {
        echo ${message}
    }

    output {
        File out = stdout()
    }

    runtime {
        cpu: ncpu
        memory: "${ramGB} GB"
        disks: disks
    }
}