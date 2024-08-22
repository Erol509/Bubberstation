/* eslint react/no-danger: "off" */
import { KEY_ENTER } from '../../common/keycodes';
import { useBackend, useLocalState } from '../backend';
import {
  Box,
  Button,
  Divider,
  Flex,
  Input,
  LabeledList,
  Section,
} from '../components';
import { Window } from '../layouts';

const Level = {
  0: 'Adminhelp',
  1: 'Mentorhelp',
  2: 'GM Request',
};

const LevelColor = {
  0: 'red',
  1: 'green',
  2: 'pink',
};

const Tag = {
  example: 'Example',
};

const State = {
  open: 'Open',
  resolved: 'Resolved',
  closed: 'Closed',
  unknown: 'Unknown',
};

type Data = {
  id: number;
  level: number;
  handler: string;
  log: string[];
};

export const TicketChat = (props, context) => {
  const { act, data } = useBackend<Data>();
  const [ticketChat, setTicketChat] = useLocalState(context, 'ticketChat');
  const { id, level, handler, log } = data;
  return (
    <Window width={900} height={600}>
      <Window.Content>
        <Section
          title={'Ticket #' + id}
          buttons={
            <Box nowrap>
              <Button color={LevelColor[level]}> {Level[level]} </Button>
            </Box>
          }
        >
          <LabeledList>
            <LabeledList.Item label="Assignee">{handler}</LabeledList.Item>
            <LabeledList.Item label="Log" />
          </LabeledList>
          <Divider />
          <Flex direction="column">
            <Flex.Item>
              <Flex>
                <Flex.Item grow>
                  <Input
                    autoFocus
                    autoSelect
                    fluid
                    placeholder="Enter a message..."
                    value={ticketChat}
                    onInput={(e, value) => setTicketChat(value)}
                    onKeyDown={(event) => {
                      const keyCode = window.event
                        ? event.which
                        : event.keyCode;
                      if (keyCode === KEY_ENTER) {
                        act('send_msg', { msg: ticketChat });
                        setTicketChat('');
                      }
                    }}
                  />
                </Flex.Item>
                <Flex.Item>
                  <Button
                    content="Send"
                    onClick={() => {
                      act('send_msg', { msg: ticketChat });
                      setTicketChat('');
                    }}
                  />
                </Flex.Item>
              </Flex>
            </Flex.Item>
            <Divider />
            <Flex.Item>{Object.keys(log).slice(0).reverse()}</Flex.Item>
          </Flex>
        </Section>
      </Window.Content>
    </Window>
  );
};
