#include <fmt/core.h>
#include "gtest/gtest.h"
#include "helloer.h"

TEST(Example, Test) {
    EXPECT_EQ(return_one(), 1);
}
