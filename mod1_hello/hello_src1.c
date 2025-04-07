#include <linux/module.h>

static int __init hello_init(void) {
	pr_err("hello: init\n");
	return 0;
}

static void __exit hello_exit(void) {
	pr_err("hello: exit\n");
}

module_init(hello_init);
module_exit(hello_exit);

MODULE_AUTHOR("Maciej Bielski");
MODULE_DESCRIPTION("Hello driver");
MODULE_LICENSE("GPL");

