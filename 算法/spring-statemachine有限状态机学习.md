# spring-statemachine有限状态机学习



### spring-statemachine

Spring Statemachine is a framework for application developers to use state machine concepts with Spring applications

Spring Statemachine 主页: [https://projects.spring.io/spring-statemachine](https://links.jianshu.com/go?to=https%3A%2F%2Fprojects.spring.io%2Fspring-statemachine)
Spring Statemachine Github: [https://github.com/spring-projects/spring-statemachine](https://links.jianshu.com/go?to=https%3A%2F%2Fgithub.com%2Fspring-projects%2Fspring-statemachine)

## demo

### maven 中添加依赖



```xml
  <dependency>
          <groupId>org.springframework.statemachine</groupId>
          <artifactId>spring-statemachine-core</artifactId>
          <version>2.0.2.RELEASE</version>
      </dependency>
```

### 定义状态和事件



```java
public enum FSMStates {
    A, B, C, D
}
enum FSMEvents {
    ToA, ToB, ToC, ToD
}
```

### 配置 StatemachineConfigurer



```java
package com.wtx.springboot2.statemachine;

import org.springframework.context.annotation.Configuration;
import org.springframework.statemachine.action.Action;
import org.springframework.statemachine.config.EnableStateMachine;
import org.springframework.statemachine.config.EnumStateMachineConfigurerAdapter;
import org.springframework.statemachine.config.builders.StateMachineConfigurationConfigurer;
import org.springframework.statemachine.config.builders.StateMachineStateConfigurer;
import org.springframework.statemachine.config.builders.StateMachineTransitionConfigurer;

import java.util.EnumSet;

/**
 * @Author wtx
 * @Date 2019/6/2
 */
@Configuration
@EnableStateMachine
public class StatemachineConfigurer extends EnumStateMachineConfigurerAdapter<FSMStates, FSMEvents> {
    @Override
    public void configure(StateMachineStateConfigurer<FSMStates, FSMEvents> states)
            throws Exception {
        states
                .withStates()
                // 初识状态：A
                .initial(FSMStates.A)
                .states(EnumSet.allOf(FSMStates.class));
    }

    @Override
    public void configure(StateMachineTransitionConfigurer<FSMStates, FSMEvents> transitions)
            throws Exception {
        transitions
                .withExternal()
                .source(FSMStates.A).target(FSMStates.B)
                .event(FSMEvents.ToB).action(customerA2B())
                .and()
                .withExternal()
                .source(FSMStates.B).target(FSMStates.C)
                .event(FSMEvents.ToC).action(customerB2C())
                .and()
                .withExternal()
                .source(FSMStates.C).target(FSMStates.D)
                .event(FSMEvents.ToD).action(customerC2D())
                .and()
                .withExternal()
                .source(FSMStates.D).target(FSMStates.A)
                .event(FSMEvents.ToA).action(customerD2A());
    }

    @Override
    public void configure(StateMachineConfigurationConfigurer<FSMStates, FSMEvents> config)
            throws Exception {
        config.withConfiguration()
                .machineId("stateMachine");
    }

    public Action<FSMStates, FSMEvents> customerA2B() {
        return context -> System.out.println("A->B");
    }

    public Action<FSMStates, FSMEvents> customerB2C() {
        return context -> System.out.println("B->C");
    }

    public Action<FSMStates, FSMEvents> customerC2D() {
        return context -> System.out.println("C->D");
    }

    public Action<FSMStates, FSMEvents> customerD2A() {
        return context -> System.out.println("D->A");
    }

}
```

### 测试 demo



```java
package com.wtx.springboot2.statemachine;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.statemachine.StateMachine;

/**
 * @Author wtx
 * @Date 2019/6/2
 */
@SpringBootApplication
public class StatemachineApplication implements CommandLineRunner {
    @Autowired
    private StateMachine<FSMStates, FSMEvents> stateMachine;

    @Override
    public void run(String... args) throws Exception {
        stateMachine.start();
        System.out.println("------");
        stateMachine.sendEvent(FSMEvents.ToB);
        System.out.println("------");
        stateMachine.sendEvent(FSMEvents.ToC);
        System.out.println("------");
        stateMachine.sendEvent(FSMEvents.ToD);
        System.out.println("------");
        stateMachine.sendEvent(FSMEvents.ToA);
        stateMachine.stop();
    }


    public static void main(String[] args) {
        SpringApplication.run(StatemachineApplication.class, args);
    }
}
```



```xml
------
A->B
------
B->C
------
C->D
------
D->A
```