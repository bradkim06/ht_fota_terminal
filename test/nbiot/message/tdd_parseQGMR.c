#include "nbiotModem.h"
#include "nbiotResponse.h"
#include "unity.h"
#include "tdd.h"

typedef struct {
	char string[50];
	char expect[15];
	int result;
} inputData_t;

inputData_t testData[2] = {
	{ .string = "..BC95GJBR02A02_LGU....OK..", .expect = "BC95GJBR02A02_", .result = 1 },
	{ .string = "..C95GJBR02A02_LGU....OK..", .expect = "", .result = 0 }
};

static Modem_t modem;

void setUp(void)
{
}

void tearDown(void)
{
}

static void testFunction(int i)
{
	memset(&modem, 0, sizeof(Modem_t));

	int result = parseQGMR(testData[i].string, &modem);
	TEST_ASSERT_EQUAL_INT(testData[i].result, result);
	TEST_ASSERT_EQUAL_STRING(testData[i].expect, modem.FwVer);
	tddPrint("input : %s\nparseFwVer : %s\n", testData[i].string, modem.FwVer);
}

void test_tdd_parseQGMR(void)
{
	char msg[100];
	for (int i = 0; i < sizeof(testData) / sizeof(inputData_t); i++) {
		sprintf(msg, "Test Case %d", i);
		TEST_MESSAGE(msg);
		testFunction(i);
	}
}
