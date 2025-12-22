#include "hC74Production.h"
#include "ProductionRunner.h"

int main(int argc, char** argv)
{
    hC74Production production;
    ProductionRunner productionRunner(production);
    productionRunner.run();

    return 0;
}
