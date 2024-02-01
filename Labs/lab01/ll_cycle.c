#include <stddef.h>
#include "ll_cycle.h"

int ll_has_cycle(node *head) {
    node *tortoise = head, *hare = head;

    do {
        if (hare == NULL || hare->next == NULL) {
            return 0;
        }

        hare = hare->next->next;
        tortoise = tortoise->next;

    } while (tortoise != hare);
    
    return 1;
}