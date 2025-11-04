#include <stdint.h>

#include "console.h"
#include "microwatt_util.h"

void usb_wait_done(void) {
	while (!(readl(USB_BASE + USB_IRQ_STS) & ((1 << 1))));
	// Clear DONE
	writel((1 << 1), USB_BASE + USB_IRQ_ACK);
}

void usb_init(){

	//USB CTRL Reg
	writel(0x03, USB_BASE+USB_CTRL);

	//USB IRQ
	writel(0x01, USB_BASE+USB_IRQ_MASK);

}

int main(void)
{
	console_init();

	microwatt_alive();

	usb_init();

	writel(0xAA, USB_BASE + USB_WR_DATA);
	//writel(0xBB, USB_BASE + USB_WR_DATA);

	//Send data
	writel(0x04, USB_BASE+USB_XFER_DATA);
	writel(0x80020000, USB_BASE+USB_XFER_TOKEN);

	//Wait for Completion
	usb_wait_done();
}

