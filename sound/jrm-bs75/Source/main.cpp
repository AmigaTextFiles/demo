#include "HangOnProduction.h"
#include "ProductionRunner.h"

int main(int argc, char** argv)
{
    HangOnProduction hangOnProduction;
    ProductionRunner productionRunner(hangOnProduction);
    productionRunner.run();

    return 0;
}
