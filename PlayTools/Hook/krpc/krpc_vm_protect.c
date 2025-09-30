#include <stdio.h>
#include <unistd.h>
#include <mach/mach.h>
// #include <servers/bootstrap.h>
#include "krpc.h"

extern kern_return_t
bootstrap_look_up(mach_port_t bp, const char *service_name, mach_port_t *sp);

kern_return_t rpc_vm_protect(
    mach_port_t mach_port,
    int64_t address,
    int64_t size,
    int32_t set_maximum,
    int32_t protection) {
    
    mach_port_t server_port;
    kern_return_t kr;

    kr = bootstrap_look_up(bootstrap_port, "com.krpc.vm_protect", &server_port);
    
    if (kr != KERN_SUCCESS) {
        printf("bootstrap_look_up failed: %d\n", kr);
        return kr;
    }
    
    kr = krpc_vm_protect(server_port, getpid(), address, size, set_maximum, protection);

    return kr;
}
