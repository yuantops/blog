+++
Categories = ["Tech"]
Description = "有限状态机的Java简单实现。"
Tags = ["java"]
date = "2017-10-12T14:30:53+08:00"
title = "整理Java有限状态机"

+++

## 有限状态机FSM及它的构成要素<a id="sec-1-1" name="sec-1-1"></a>

The FSM can change from one state to another in response to some external inputs; the change from one state to another is called a transition. An FSM is defined by a list of its states, its initial state, and the conditions for each transition.

有限状态机由状态集合, 初始状态, 状态转移条件定义。

## Java实现<a id="sec-1-2" name="sec-1-2"></a>

根据FSM定义，可以抽象出Java的3种数据类型：

-   状态(State)
-   事件(Event)
    
    事件触发状态转移，是状态机的输入。

-   上下文(Context) 
    
    上下文，可以包含各种Condition。

例子：当前状态A，此时输入事件E，如果满足条件C，会导致状态A转换到状态B。这种情况下，A,B是State，E是Event，C是Context下的Condition。

## 具体代码<a id="sec-1-3" name="sec-1-3"></a>

1.  状态机运行
    
        public State run() {
            for (State s = initState; s != null; s = s.next(context)) {
            // do something here
            }
            return state;
        }

2.  State, Event用Enum, 且State一定包含next() method
    
        public enum State {
        
            INIT(0, "未初始化") {
                @Override
                public State next(Context context) {
                    switch (context.getEvent()) {
                        case Event1:
                            return context.condition1() ? STATE_1 : STATE_2;
                        default:
                            return null;
                    }
                }
            },
            STATE_1(1, "状态1") {
                @Override
                public State next(Context context) {
                    context.setState(STATE_1);
                    switch (context.getEvent()) {
                        case Event1:
                            return context.condition2() ? STATE_3 : null;
                        default:
                            return null;
                    }
                }
            };
        
            private Byte code;
            private String desc;
        
            State(int code, String desc) {
                this.code = (byte) code;
                this.desc = desc;
            }
        
            public abstract State next(Context context);
        }

3.  Context是一系列Condition组合得到的interface
    
        public interface Context {
            void setState(State state);
        
            /**
             * 得到Event input
             * @return
             */
            EventEnum getEvent();
        
            /**
             * 是否满足条件1
             * @return
             */
            Boolean condition1();
        }

4.  组合得到FSM的定义
    
        class FSM implements Context {
        
             private EventEnum event;
        
             private State    state;
        
             public FSM(State initState) {
                 this.state = initState;
             }
        
             public State run() {
                 for (State s = initState; s != null; s = s.next(this)) {
                 }
                 return state;
             }
        
             @Override
             public EventEnum getEvent() {
                 return event;
             }
        
             //implements conditions 
        }
