import io.kotest.core.spec.style.StringSpec
import io.kotest.matchers.collections.*
import io.kotest.matchers.comparables.*
import io.kotest.matchers.ints.*
import io.kotest.matchers.nulls.*
import io.kotest.matchers.string.*
import io.kotest.matchers.maps.*
import io.kotest.matchers.booleans.*
import io.kotest.matchers.throwable.*

class KotestMatchersDemoTest : StringSpec({

    // String Matchers
    "should demonstrate string matchers" {
        val text = "Hello, Kotest!"
        text.shouldStartWith("Hello")
        text.shouldContain("Kotest")
        text.shouldHaveLength(13)
        text.shouldEndWith("!")
        text.shouldNotContain("Goodbye")
    }

    // Null Matchers
    "should demonstrate null matchers" {
        val nullableString: String? = null
        nullableString.shouldBeNull()

        val nonNullableString: String? = "I am not null"
        nonNullableString.shouldNotBeNull()
    }

    // Integer Matchers
    "should demonstrate integer matchers" {
        val number = 42
        number.shouldBeGreaterThan(40)
        number.shouldBeLessThan(50)
        number.shouldBeBetween(40, 50)
        number.shouldBePositive()
        number.shouldNotBeNegative()
    }

    // Collection Matchers
    "should demonstrate collection matchers" {
        val list = listOf(1, 2, 3, 4, 5)
        list.shouldHaveSize(5)
        list.shouldContain(3)
        list.shouldContainExactly(1, 2, 3, 4, 5)
        list.shouldNotBeEmpty()
        list.shouldBeSorted()
    }

    // Map Matchers
    "should demonstrate map matchers" {
        val map = mapOf("key1" to "value1", "key2" to "value2")
        map.shouldContainKey("key1")
        map.shouldContainValue("value2")
        map.shouldContainExactly(mapOf("key1" to "value1", "key2" to "value2"))
    }

    // Boolean Matchers
    "should demonstrate boolean matchers" {
        val condition = true
        condition.shouldBeTrue()

        val anotherCondition = false
        anotherCondition.shouldBeFalse()
    }

    // Throwable Matchers
    "should demonstrate throwable matchers" {
        val exception = IllegalArgumentException("Invalid argument")
        val function = { throw exception }

        function.shouldThrow<IllegalArgumentException>()
        function.shouldThrowExactly<IllegalArgumentException>()
    }
})