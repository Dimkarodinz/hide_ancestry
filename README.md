[![Build Status](https://travis-ci.org/Dimkarodinz/hide_ancestry.svg?branch=master)](https://travis-ci.org/Dimkarodinz/hide_ancestry)
# HideAncestry
This gem allows hide and restore nodes of [ancestry](https://github.com/stefankroes/ancestry)

### Usage
State before hiding:
```
$ User.first.subtree
$ #<ActiveRecord::Relation [
    <id: 1, name: 'Grandpa', hidden_status: false, ancestry: nil, hide_ancestry: 1>,
      <id: 2, name: 'Parent', hidden_status: false, ancestry: '1', hide_ancestry: '1/2'>,
        <id: 3, name: 'Child', hidden_status: false, ancestry: '1/2', hide_ancestry '1/2/3'> ]>
```

####Hiding
```
$ User.second.hide
```

Ancestry subtree became changed:
```
$ User.first.subtree
$ #<ActiveRecord::Relation [
    <id: 1, name: 'Grandpa', hidden_status: false, ancestry: nil, hide_ancestry: '1'>,
      <id: 3, name: 'Child', hidden_status: false, ancestry: '1', hide_ancestry: '1/2/3'> ]>

$ User.hidden
$ <ActiveRecord::Relation [
    <id: 2, name: 'Parent', hidden_status: true, ancestry: nil, hide_ancestry: '1/2'> ]>
```

####Restoring hidden node:
```
$ User.find(2).restore # restore hidden node to previous subtree

$ User.first.subtree
    <id: 1, name: 'Grandpa', hidden_status: false, ancestry: nil, hide_ancestry: '1'>,
      <id: 2, name: 'Parent', hidden_status: false, ancestry: '1', hide_ancestry: '1/2'>,
        <id: 3, name: 'Child', hidden_status: false, ancestry: '1/2', hide_ancestry: '1/2/3'>

User.hidden
$ #<ActiveRecord::Relation []>
```

####Hiding, updating subtree and restoring hidden node
```
$ User.find(2).hide
$ User.find_by(name: 'Grandpa').update parent_id: 4

# hide_ancestry of each node of subtree became updated
$ User.find(4).subtree
    <id: 4, name: 'Root User', hidden_status: false, ancestry: nil, hide_ancestry: '4'>,
       <id: 1, name: 'Grandpa', hidden_status: false, ancestry: '1', hide_ancestry: '4/1'>,
          <id: 3, name: 'Child', hidden_status: false, ancestry: '1/2', hide_ancestry: '4/1/2/3'>

# hidden node update its hide_ancestry too
$ User.hidden
$ <ActiveRecord::Relation [
   <id: 2, name: 'Parent', hidden_status: true, ancestry: nil, hide_ancestry: '4/1/2'> ]>

# You can look on subtree with hidden node
$ User.find(4).subtree_with_hidden
    <id: 4, name: 'Root User', hidden_status: false, ancestry: nil, hide_ancestry: '4'>,
       <id: 1, name: 'Grandpa', hidden_status: false, ancestry: '1', hide_ancestry: '4/1'>,
          <id: 2, name: 'Parent', hidden_status: true, ancestry: nil, hide_ancestry: '4/1/2'>,
             <id: 3, name: 'Child', hidden_status: false, ancestry: '1/2', hide_ancestry: '4/1/2/3'>

# Restoring still works correctly
$ User.find(2).restore
$ User.find(4).subtree
    <id: 4, name: 'Root User', hidden_status: false, ancestry: nil, hide_ancestry: '4'>,
       <id: 1, name: 'Grandpa', hidden_status: false, ancestry: '1', hide_ancestry: '4/1'>,
          <id: 2, name: 'Parent', hidden_status: false, ancestry: '1/2', hide_ancestry: '4/1/2'>,
            <id: 3, name: 'Child', hidden_status: false, ancestry: '1/2/3', hide_ancestry: '4/1/2/3'>
```

+ You can change ancestry subtree as you want after node hiding. hidden node still can be restored to previous parent and still will join correctly it old descendants (unless you changed descendant`s parent).
+ hidden nodes have nil ancestry columns - no any actual parents or descendants present. 

### Installation
Add to your Gemfile
``` ruby
gem 'ancestry'
gem 'hide_ancestry'
```
And run
```
bundle install
```
To install hide_ancestry migration:
```ruby
# Set any table with ancestry.
# Type --no-hidden-status if you are going to use your own boolean column for hiding nodes
rails generate hide_ancestry_migration users [--no-hidden-status]
rake db:migrate
```
It will add to the specified table:
+ old_parent_id:integer
+ old_child_ids:text   (will be array - thanks to rails serialize)
+ hide_ancestry:string
+ hidden_status:boolean (unless --no-hidden-status option)

Then add to your model:
```ruby
class User < ActiveRecord::Base
  has_ancestry
  has_hide_ancestry
end
```
Now you are able to use hide_ancestry methods.

###Instance methods
```ruby
hide                      # hide node
restore                   # restore hidden node

hidden?                    # check if node is hidden
hidden_parent_changed?     # check if regular node changed it hidden parent
hidden_children_present?   # check if regular node has hidden children

hidden_parent              # returns hidden parent of regular node (if present)
subtree_with_hidden        # returns subtree of regular node with hidden nodes

children_of_hidden         # returns children of hidden node
hidden_descendants_ids     # returns ids of hidden nodes in subtree of regular node 
hide_ancestry_ids         # old ancestors ids of hidden node
depth_with_hidden          # returns depth of node given hidden nodes

```

###Scopes
```ruby
hidden            # returns nodes with hidden_status (or you custom column)
unhidden          # returns nodes without hidden_status
hidden_nodes(ids) # look for hidden nodes with ids
hidden_childs(id) # returns hidden children nodes of node#id

```

###Options for has_hide_ancestry
```ruby
# You can delete hidden_status if you use this
use_column: :you_custom_boolean_column
```