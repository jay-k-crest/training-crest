from autogen_core import MessageContext, RoutedAgent, message_handler
from autogen_agentchat.agents import AssistantAgent
from autogen_agentchat.messages import TextMessage
import messages
import random
import asyncio
from dotenv import load_dotenv
import os

load_dotenv(override=True)

class Agent(RoutedAgent):
    system_message = "I am an expert in providing creative solutions to complex problems."
    CHANCES_THAT_I_BOUNCE_IDEA_OFF_ANOTHER = 0.3

    def __init__(self, name) -> None:
        super().__init__(name)
        self.model_client = None
        self._delegate = None

    async def ensure_delegate(self):
        if self._delegate is None:
            from agent import create_groq_client
            self.model_client = await create_groq_client(temperature=0.8)
            self._delegate = AssistantAgent(self.id.key, model_client=self.model_client, system_message=self.system_message)

    @message_handler
    async def handle_message(self, message: messages.Message, ctx: MessageContext) -> messages.Message:
        await self.ensure_delegate()
        text_message = TextMessage(content=message.content, source="user")
        response = await self._delegate.on_messages([text_message], ctx.cancellation_token)
        return messages.Message(content=response.chat_message.content)