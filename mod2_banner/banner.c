#include <linux/module.h>
#include <linux/sysctl.h>

#define BANNER_SZ 512

static int banner_dostring(struct ctl_table *table, int write,
                           void *buffer, size_t *lenp, loff_t *ppos)
{
    int ret = proc_dostring(table, write, buffer, lenp, ppos);
    if (write)
        pr_err("banner: [%c] setting new value %s\n",
               (ret ? '-' : '+'), (ret ? "FAILED" : "SUCCEEDED"));

    return ret;
}

static char banner_string[BANNER_SZ] = "test-banner";

static struct ctl_table banner_table[] = {
    {
        .procname = "banner",
        .data = banner_string,
        .maxlen = BANNER_SZ,
        .mode = 0644,
        .proc_handler = banner_dostring
    }
};

static struct ctl_table_header *banner_table_header;

static int __init banner_init(void) {
    pr_err("banner: init\n");

    /*
     * ERROR: modpost: "__register_sysctl_init" [/home/mbielski/ws/kernelDev/mod2_banner/banner.ko] undefined!
     *
     * Symbol not exported because meant to be used by non-modular code only
     * see: fs/proc/proc_sysctl.c
     *
     */
    // register_sysctl_init("module", banner_table);
    banner_table_header = register_sysctl("module", banner_table);
    if (!banner_table_header)
        goto table_err;
    pr_err("banner: [+] sysctl table registered\n");

out:
    return 0;

table_err:
    pr_err("banner: [-] sysctl table registration failed\n");
    unregister_sysctl_table(banner_table_header);
    banner_table_header = NULL;
    goto out;
}

static void __exit banner_exit(void) {
    pr_err("banner: exit\n");

    unregister_sysctl_table(banner_table_header);
    banner_table_header = NULL;
}

module_init(banner_init);
module_exit(banner_exit);

MODULE_AUTHOR("Maciej Bielski");
MODULE_DESCRIPTION("Banner driver");
MODULE_LICENSE("GPL");
