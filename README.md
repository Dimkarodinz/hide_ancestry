[![Build Status](https://travis-ci.org/Dimkarodinz/hide_ancestry.svg?branch=master)](https://travis-ci.org/Dimkarodinz/hide_ancestry)
# HideAncestry
This gem allows hide and restore nodes of [ancestry](https://github.com/stefankroes/ancestry)

### Usage
State before hiding:
```
$ User.first.subtree
$ #<ActiveRecord::Relation [
    <id: 1, name: 'Grandpa', hided_status: false, ancestry: nil, hide_ancestry: 1>,
      <id: 2, name: 'Parent', hided_status: false, ancestry: '1', hide_ancestry: '1/2'>,
        <id: 3, name: 'Child', hided_status: false, ancestry: '1/2', hide_ancestry '1/2/3'> ]>
```

####Hiding
```
$ User.second.hide
```

Ancestry subtree became changed:
```
$ User.first.subtree
$ #<ActiveRecord::Relation [
    <id: 1, name: 'Grandpa', hided_status: false, ancestry: nil, hide_ancestry: '1'>,
      <id: 3, name: 'Child', hided_status: false, ancestry: '1', hide_ancestry: '1/2/3'> ]>

$ User.hided
$ <ActiveRecord::Relation [
    <id: 2, name: 'Parent', hided_status: true, ancestry: nil, hide_ancestry: '1/2'> ]>
```

####Restoring hided node:
```
$ User.find(2).restore # restore hided node to previous subtree

$ User.first.subtree
    <id: 1, name: 'Grandpa', hided_status: false, ancestry: nil, hide_ancestry: '1'>,
      <id: 2, name: 'Parent', hided_status: false, ancestry: '1', hide_ancestry: '1/2'>,
        <id: 3, name: 'Child', hided_status: false, ancestry: '1/2', hide_ancestry: '1/2/3'>

User.hided
$ #<ActiveRecord::Relation []>
```

####Hiding, updating subtree and restoring hided node
```
$ User.find(2).hide
$ User.find_by(name: 'Grandpa').update parent_id: 4

# hide_ancestry of each node of subtree became updated
$ User.find(4).subtree
    <id: 4, name: 'Root User', hided_status: false, ancestry: nil, hide_ancestry: '4'>,
       <id: 1, name: 'Grandpa', hided_status: false, ancestry: '1', hide_ancestry: '4/1'>,
          <id: 3, name: 'Child', hided_status: false, ancestry: '1/2', hide_ancestry: '4/1/2/3'>

# Hided node update its hide_ancestry too
$ User.hided
$ <ActiveRecord::Relation [
   <id: 2, name: 'Parent', hided_status: true, ancestry: nil, hide_ancestry: '4/1/2'> ]>

# You can look on subtree with hided node
$ User.find(4).subtree_with_hided
    <id: 4, name: 'Root User', hided_status: false, ancestry: nil, hide_ancestry: '4'>,
       <id: 1, name: 'Grandpa', hided_status: false, ancestry: '1', hide_ancestry: '4/1'>,
          <id: 2, name: 'Parent', hided_status: true, ancestry: nil, hide_ancestry: '4/1/2'>,
             <id: 3, name: 'Child', hided_status: false, ancestry: '1/2', hide_ancestry: '4/1/2/3'>

# Restoring still works correctly
$ User.find(2).restore
$ User.find(4).subtree
    <id: 4, name: 'Root User', hided_status: false, ancestry: nil, hide_ancestry: '4'>,
       <id: 1, name: 'Grandpa', hided_status: false, ancestry: '1', hide_ancestry: '4/1'>,
          <id: 2, name: 'Parent', hided_status: false, ancestry: '1/2', hide_ancestry: '4/1/2'>,
            <id: 3, name: 'Child', hided_status: false, ancestry: '1/2/3', hide_ancestry: '4/1/2/3'>
```

+ You can change ancestry subtree as you want after node hiding. Hided node still can be restored to previous parent and still will join correctly it old descendants (unless you changed descendant`s parent).
+ Hided nodes have nil ancestry columns - no any actual parents or descendants present. 

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
# Type --no-hided-status if you are going to use your own boolean column for hiding nodes
rails generate hide_ancestry_migration users [--no-hided-status]
rake db:migrate
```
It will add to the specified table:
+ old_parent_id:integer
+ old_child_ids:text   (will be array - thanks to rails serialize)
+ hide_ancestry:string
+ hided_status:boolean (unless --no-hided-status option)

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
restore                   # restore hided node

hided?                    # check if node is hided
hided_parent_changed?     # check if regular node changed it hided parent
hided_children_present?   # check if regular node has hided children

hided_parent              # returns hided parent of regular node (if present)
subtree_with_hided        # returns subtree of regular node with hided nodes

children_of_hided         # returns children of hided node
hided_descendants_ids     # returns ids of hided nodes in subtree of regular node 
hide_ancestry_ids         # old ancestors ids of hided node
depth_with_hided          # returns depth of node given hided nodes

```

###Scopes
```ruby
hided            # returns nodes with hided_status (or you custom column)
unhided          # returns nodes without hided_status
hided_nodes(ids) # look for hided nodes with ids
hided_childs(id) # returns hided children nodes of node#id

```

###Options for has_hide_ancestry
```ruby
# You can delete hided_status if you use this
use_column: :you_custom_boolean_column
```