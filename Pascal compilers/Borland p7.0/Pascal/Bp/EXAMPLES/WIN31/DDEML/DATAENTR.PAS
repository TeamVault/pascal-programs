{***************************************************}
{                                                   }
{   Windows 3.1 DDEML Demonstration Program         }
{   Copyright (c) 1992 by Borland International     }
{                                                   }
{***************************************************}

{ This unit defines the interface to the DataEntry DDE
  server (DDEMLSRV.PAS).  It defines the Service, Topic,
  and Item names supported by the Server, and also defines
  a data structure which may be used by the Client to
  hold the sampled data locally.

  The Data Entry Server makes its data samples available
  in text (cf_Text) form as three separate Topics.  Clients
  may convert these into integer form for use with the
  data structure defined here.
}
unit DataEntry;

interface

const
  NumValues = 3;

type

{ Data Structure which constitutes a sample }

  TDataSample = array [1..NumValues] of Integer;
  TDataString = array [0..20] of Char;     { Size of Item as text }

const
  DataEntryName : PChar = 'DataEntry';
  DataTopicName : PChar = 'SampledData';
  DataItemNames : array [1..NumValues] of PChar = ('DataItem1',
                                                   'DataItem2',
                                                   'DataItem3');

implementation

end.
