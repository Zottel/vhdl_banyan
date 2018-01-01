=====================================
BANYAN NETWORK IMPLEMENTATION IN VHDL
=====================================

Notice::

  Copyright 2018 Julius Roob <julius@juliusroob.de>

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.



About
-------
This is a blocking banyan network as a message passing interconnect.

Architecture
------------
Recursive definition::

   banyan_network(s, s_n)       +     inputs
                                |
  +-----------------------------------------------------------+
  |                             |                             |
  |                        +----+----+                        |
  |                        |         |                        |
  | +----------------------v---+ +---v----------------------+ |
  | |                          | |                          | |
  | | banyan_network(s-1, s_n) | | banyan_network(s-1, s_n) | |
  | |                          | |                          | |
  | +----------------------+---+ +---+----------------------+ |
  |                        |         |                        |
  |                        +----+----+ pre_permutation        |
  |                             |                             |
  | +---------------------------v---------------------------+ |
  | |                                                       | |
  | | banyan_permutation_butterfly(s)                       | |
  | |                                                       | |
  | +---------------------------+---------------------------+ |
  |                             |                             |
  |                             |      post_permutation       |
  |                             |                             |
  | +---------------------------v---------------------------+ |
  | |                                                       | |
  | | switch_column(s, s_n)                                 | |
  | |                                                       | |
  | +---------------------------+---------------------------+ |
  |                             |                             |
  +-----------------------------------------------------------+
                                |
                                +      outputs

