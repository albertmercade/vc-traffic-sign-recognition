function aTable = flatten(aTable, aStruct)
fields = fieldnames(aStruct);
for idx = 1:length(fields)
   aField = aStruct.(fields{idx});
   if isstruct(aField)
     aTable = flatten(aTable, aField);
   else
     % add to the table what you want, e.g., if it's a number:
    aField
    aTable
     aTable(end+1) = aField;
   end
end